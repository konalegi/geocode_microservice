# frozen_string_literal: true

describe Route::ImportCityBoundaries do
  let(:kazan) do
    {
      name: :kazan,
      file_name: "#{Rails.root}/lib/city_data/kazan.wkt",
      lat: 55.798551,
      lon: 49.106324
    }
  end

  let(:saratov) do
    {
      name: :saratov,
      file_name: "#{Rails.root}/lib/city_data/saratov.wkt",
      lat: 51.5923654,
      lon: 45.9608031
    }
  end

  let(:city_boundaries) { [kazan, saratov] }

  subject do
    described_class.call(city_boundaries: city_boundaries)
  end

  context 'full import' do
    let(:imported_count) { CITY_BOUNDARIES_DATA.count }
    let(:city_boundaries) { nil }

    specify do
      expect { subject }.to change { City.count }.by(imported_count)
    end
  end

  context 'skip error imports' do
    let(:kazan) { super().merge(lat: nil, lon: nil) }
    before do
      expect(described_class).to receive(:log)
        .with(/null value in column "lat" violates not-null constraint/)
    end

    specify do
      expect { subject }.to change { City.count }.by(1)
    end
  end

  context 'validates for uniqueness' do
    let(:saratov) { super().merge(name: :kazan) }
    before do
      expect(described_class).to receive(:log)
        .with(/duplicate key value violates unique constraint/)
    end

    specify do
      expect { subject }.to change { City.count }.by(1)
    end
  end
end
