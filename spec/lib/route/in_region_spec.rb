# frozen_string_literal: true

describe Route::InRegion do
  include Mocks::Google::DirectionsApi

  let(:city_name) { :kazan }
  let(:city_data) { CITY_BOUNDARIES_DATA.select { |v| v[:name] == city_name }.first }
  let(:distance) { rand(100..1000) }
  let(:initial_src) { city_data.slice(:lat, :lon) }
  let(:dst) do
    { lat: 55.8631524, lon: 48.3336645 }
  end

  before do
    Route::ImportCityBoundaries.call(city_boundaries: [city_data])
    mock_google_api_routes_request(dst: dst, src: initial_src)
  end

  subject do
    described_class.distance_from_city(city_name: city_name, dst: dst)
  end

  context 'when has intersection' do
    let(:intersection_point) { { lat: 55.8590428451511, lon: 48.8491807535057 } }

    before do
      mock_google_api_routes_request(dst: dst, src: intersection_point, distance: distance)
    end

    it 'returns distance' do
      expect(subject).to eq(distance)
    end
  end

  context 'when no intersection' do
    let(:dst) do
      { lat: 55.7716472, lon: 49.2374026 }
    end

    it 'raises error' do
      expect { subject }.to raise_error(Route::InRegion::NoIntersectionFound)
    end
  end
end
