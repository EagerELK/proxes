# frozen_string_literal: true

require 'spec_helper'
require 'logger'
require 'proxes/middleware/error_handling'
require 'pundit'

describe ProxES::Middleware::ErrorHandling do
  context '.new' do
    it 'takes a logger as a parameter' do
      logger = double(Logger)
      eh = ProxES::Middleware::ErrorHandling.new(proc { [200, {}, ['Hello, world.']] }, logger)
      expect(eh.logger).to be logger
    end
  end

  context 'calls' do
    context 'that are successful' do
      def app
        ProxES::Middleware::ErrorHandling.new(proc { [200, {}, ['Hello, world.']] })
      end

      it 'does nothing' do
        get('/')
        expect(last_response.status).to eq 200
      end
    end

    context 'that fail with unreachable' do
      def app
        ProxES::Middleware::ErrorHandling.new(proc { raise Errno::EHOSTUNREACH })
      end

      it 'responds with a 500' do
        get('/')
        expect(last_response.status).to eq 500
      end

      it 'reports the error' do
        get('/')
        expect(last_response.body).to include 'Could not reach Elasticsearch at '
      end
    end

    context 'that fail with connection refused' do
      def app
        ProxES::Middleware::ErrorHandling.new(proc { raise Errno::ECONNREFUSED })
      end

      it 'responds with a 500' do
        get('/')
        expect(last_response.status).to eq 500
      end

      it 'reports the error' do
        get('/')
        expect(last_response.body).to include 'Elasticsearch not listening at '
      end
    end

    context 'that fails authorization' do
      def app
        ProxES::Middleware::ErrorHandling.new(proc { raise Pundit::NotAuthorizedError })
      end

      it 'responds with a 401' do
        get('/')
        expect(last_response.status).to eq 401
      end

      it 'reports the error' do
        get('/')
        expect(last_response.body).to include 'Not Authorized'
      end

      it 'redirects HTML requests to a login page' do
        header 'Accept', 'text/html'
        get('/')
        expect(last_response.status).to eq 302
        expect(last_response.headers).to include 'Location'
      end
    end

    context 'that fails' do
      def app
        ProxES::Middleware::ErrorHandling.new(proc { raise 'Some Error' })
      end

      it 'responds with a 403' do
        get('/')
        expect(last_response.status).to eq 403
      end

      it 'reports the error' do
        get('/')
        expect(last_response.body).to include 'Forbidden'
      end
    end
  end
end
