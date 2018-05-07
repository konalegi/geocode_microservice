# frozen_string_literal: true

describe 'GET /api/geocode', type: :request do
  let(:url) { '/api/geocode' }
  let(:address) { SecureRandom.hex }

  let(:params) do
    { address: address }
  end

  before do
    mock_request
    get url, params: params
  end

  context 'success' do
    let(:mock_request) do
      expect(LocationClient).to receive(:geocode).with(address: address).and_return(result)
    end

    let(:result) do
      { lattitude: 10, longitude: 10, city: SecureRandom.hex }
    end

    specify do
      expect(response).to have_http_status(200)
      expect(parsed_body).to eq(result.stringify_keys)
    end

    context 'when adapter selected' do
      let(:adapter_name) { 'google' }
      let(:params) { super().merge(adapter_name: adapter_name) }

      let(:mock_request) do
        expect(LocationClient).to receive(:geocode).
          with(address: address, adapter_name: adapter_name).and_return(result)
      end

      specify do
        expect(response).to have_http_status(200)
        expect(parsed_body).to eq(result.stringify_keys)
      end
    end
  end

  context 'when invalid adaptername is provided' do
    let(:mock_request) do
      expect(LocationClient).to receive(:geocode).and_raise(LocationClient::AdapterNotFound)
    end

    specify do
      expect(response).to have_http_status(422)
      expect(parsed_body['errors']).to eq(['LocationClient::AdapterNotFound'])
    end
  end

  context 'failure' do
    let(:mock_request) do
      expect(LocationClient).to receive(:geocode).and_raise(LocationClient::NotFoundError)
    end

    specify { expect(response).to have_http_status(404) }
  end
end
