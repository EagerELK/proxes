# frozen_string_literal: true

module ProxES
  module Helpers
    module Views
      def form_control(name, model, opts = {})
        label = opts.delete(:label) || name.to_s.titlecase
        klass = opts.delete(:class) || 'form-control' unless opts[:type] == 'file'
        group = opts.delete(:group) || model.class.to_s.demodulize.underscore
        field = opts.delete(:field) || name

        attributes = { type: 'text', id: name, name: "#{group}[#{name}]", class: klass }.merge(opts)
        locals = { model: model, label: label, attributes: attributes, name: name, group: group, field: field }
        haml :'partials/form_control', locals: locals
      end

      def flash_messages(key = :flash)
        return '' if flash(key).empty?
        id = (key == :flash ? 'flash' : "flash_#{key}")
        messages = flash(key).collect do |message|
          "  <div class='alert alert-#{message[0]} alert-dismissable' role='alert'>#{message[1]}</div>\n"
        end
        "<div id='#{id}'>\n" + messages.join + '</div>'
      end

      def delete_form(entity, label = 'Delete')
        locals = { delete_label: label, entity: entity }
        haml :'partials/delete_form', locals: locals
      end

      def pagination(list, base_path)
        locals = {
          next_link: list.last_page? ? '#' : "#{base_path}?page=#{list.next_page}&count=#{list.page_size}",
          prev_link: list.first_page? ? '#' : "#{base_path}?page=#{list.prev_page}&count=#{list.page_size}",
          base_path: base_path,
          list: list
        }
        haml :'partials/pager', locals: locals
      end
    end
  end
end
