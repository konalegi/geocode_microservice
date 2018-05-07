# frozen_string_literal: true

describe Google::DirectionsApiClient do
  include Mocks::Google::DirectionsApi

  let(:status) { 'OK' }
  let(:distance) { 200 }
  let(:src) do
    { lat: rand(1..100), lon: rand(1..100) }
  end

  let(:dst) do
    { lat: rand(1..100), lon: rand(1..100) }
  end

  let!(:request) do
    mock_google_api_routes_request(
      src: src,
      dst: dst,
      status: status,
      distance: distance
    )
  end

  describe '.route' do
    subject { described_class.route(src: src, dst: dst) }

    it { expect { subject }.not_to raise_error }
  end

  describe '.route_polylines' do
    subject { described_class.route_polylines(src: src, dst: dst) }

    it { expect { subject }.not_to raise_error }
  end

  describe '.route_distance' do
    subject { described_class.route_distance(src: src, dst: dst) }

    it { expect(subject).to eq(distance) }
  end
end
