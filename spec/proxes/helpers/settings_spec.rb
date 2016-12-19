describe ProxES::Helpers::Settings do
  context '#get' do
    it 'checks the DB first for the setting'
    it 'checks the Environment second for the setting'
    it 'returns nil if it cannot find the setting'
  end

  context '#set' do
    it 'updates the DB if the setting is set in the DB'
    it 'updates the Environment if the setting is set in the Environment'
  end
end
