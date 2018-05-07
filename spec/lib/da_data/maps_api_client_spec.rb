# frozen_string_literal: true

describe DaData::MapsApiClient do
  include Mocks::DaData::MapsApi

  let(:lattitude) { 10.02 }
  let(:longitude) { 12.01 }

  describe '.geocode' do
    let(:found) { true }
    subject { described_class.geocode(address: address) }
    let(:address) { SecureRandom.hex }
    let(:city) { SecureRandom.hex }
    let!(:request) do
      mock_da_data_api_maps_geocode_request(address: address,
                                            city: city,
                                            lattitude: lattitude,
                                            longitude: longitude,
                                            found: found)
    end

    context 'success' do
      specify do
        expect(subject).to eq(longitude: longitude, lattitude: lattitude, city: city)
        expect(request).to have_been_made
      end
    end

    context 'failure' do
      context 'when geo points are nil' do
        let(:lattitude) { nil }
        let(:longitude) { nil }

        it 'raises error' do
          expect { subject }.to raise_error(::DaData::CannotFindGeoPoints)
          expect(request).to have_been_made
        end
      end

      context 'when not found' do
        let(:found) { false }
        it 'raises error' do
          expect { subject }.to raise_error(::DaData::NotFoundError)
          expect(request).to have_been_made
        end
      end

      context 'when city not found' do
        let(:found) { true }
        let(:city) { nil }

        it 'not raises error' do
          expect { subject }.not_to raise_error
          expect(request).to have_been_made
        end
      end
    end
  end

  describe '.city_disctict' do
    subject do
      described_class.city_disctict(longitude: longitude, lattitude: lattitude)
    end

    it { expect { subject }.to raise_error(::DaData::NotFoundError) }
  end
end
