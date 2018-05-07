# frozen_string_literal: true

describe LocationClient do
  include Mocks::Yandex::MapsApi
  include Mocks::Google::MapsApi
  include Mocks::DaData::MapsApi

  let(:address) { SecureRandom.hex }
  let(:city) { SecureRandom.hex }
  let(:lattitude) { rand(1..100) }
  let(:longitude) { rand(1..100) }

  let(:response) do
    { city: city, lattitude: lattitude, longitude: longitude }
  end

  let(:common_mock_params) do
    { address: address, city: city, lattitude: lattitude, longitude: longitude }
  end

  let!(:google_request) do
    mock_google_api_maps_geocode_request(common_mock_params.merge(status: google_status))
  end

  let!(:yandex_request) do
    mock_yandex_api_maps_geocode_request(common_mock_params.merge(found: yandex_found))
  end

  let!(:da_data_request) do
    mock_da_data_api_maps_geocode_request(common_mock_params.merge(found: da_data_found))
  end

  let!(:mock_adapters) do
    expect(described_class).to receive(:randomized_adapters).and_return(adapters)
  end

  let(:adapters) { [Yandex::MapsApiClient, Google::MapsApiClient, DaData::MapsApiClient] }
  let(:da_data_found) { true }
  let(:google_status) { 'OK' }
  let(:yandex_found) { true }
  let(:subject) { described_class.geocode(address: address) }

  context 'when yandex fails' do
    let(:adapters) { [Yandex::MapsApiClient, Google::MapsApiClient] }
    let(:google_status) { 'OK' }
    let(:yandex_found) { false }

    it 'uses google' do
      expect(subject).to eq(response)
      expect(google_request).to have_been_made
      expect(yandex_request).to have_been_made
    end
  end

  context 'when google fails' do
    let(:adapters) { [Google::MapsApiClient, Yandex::MapsApiClient] }
    let(:google_status) { 'ZERO_RESULTS' }
    let(:yandex_found) { true }

    it 'uses yandex' do
      expect(subject).to eq(response)
      expect(yandex_request).to have_been_made
      expect(google_request).to have_been_made
    end
  end

  context 'when google and yandex fails' do
    let(:adapters) { [Google::MapsApiClient, Yandex::MapsApiClient, DaData::MapsApiClient] }
    let(:google_status) { 'ZERO_RESULTS' }
    let(:yandex_found) { false }
    let(:da_data_found) { true }

    it 'uses dadata' do
      expect(subject).to eq(response)
      expect(yandex_request).to have_been_made
      expect(google_request).to have_been_made
      expect(da_data_request).to have_been_made
    end
  end

  context 'when all fails' do
    let!(:mock_adapters) {}
    let(:google_status) { 'ZERO_RESULTS' }
    let(:yandex_found) { false }
    let(:da_data_found) { false }

    it 'uses yandex' do
      expect { subject }.to raise_error(LocationClient::NotFoundError)
      expect(yandex_request).to have_been_made
      expect(google_request).to have_been_made
      expect(da_data_request).to have_been_made
    end
  end

  context 'select adapter' do
    let!(:mock_adapters) {}

    context 'google' do
      let(:subject) { described_class.geocode(address: address, adapter_name: 'google') }

      specify do
        expect(subject).to eq(response)
        expect(google_request).to have_been_made
        expect(yandex_request).not_to have_been_made
        expect(da_data_request).not_to have_been_made
      end
    end

    context 'yandex' do
      let(:subject) { described_class.geocode(address: address, adapter_name: 'yandex') }

      specify do
        expect(subject).to eq(response)
        expect(google_request).not_to have_been_made
        expect(yandex_request).to have_been_made
        expect(da_data_request).not_to have_been_made
      end
    end

    context 'dadata' do
      let(:subject) { described_class.geocode(address: address, adapter_name: 'dadata') }

      specify do
        expect(subject).to eq(response)
        expect(google_request).not_to have_been_made
        expect(yandex_request).not_to have_been_made
        expect(da_data_request).to have_been_made
      end
    end

    context 'unknown adapter' do
      let(:subject) { described_class.geocode(address: address, adapter_name: 'google123') }

      specify do
        expect { subject }.to raise_error(LocationClient::AdapterNotFound)
        expect(google_request).not_to have_been_made
        expect(yandex_request).not_to have_been_made
        expect(da_data_request).not_to have_been_made
      end
    end
  end
end
