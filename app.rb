require 'sinatra'
require 'json'
require 'sequel'

# Jalur ke file database SQLite
db_path = 'C:/Users/bayyi/dokter.db'

# Menghubungkan ke database SQLite
DB = Sequel.connect(adapter: 'sqlite', database: db_path)

# Model untuk Dokter
class Dokter < Sequel::Model(:dokter)
end

# Endpoint untuk mengambil semua dokter
get '/dokter' do
  content_type :json
  dokter_data = DB[:dokter].all
  dokter_data.to_json
end

# Root Route
get '/' do
  'Dokter Service is running!'
end

# Add a new dokter
post '/dokter' do
    content_type :json
  
    # Membaca JSON dari body permintaan
    request_payload = JSON.parse(request.body.read)
  
    # Validasi input
    if request_payload['Nama'].nil? || request_payload['Spesialis'].nil?
      halt 400, { error: "Name and specialty are required." }.to_json
    end
  
    # Membuat dokter baru
    begin
      new_dokter = Dokter.create(
        Nama: request_payload['Nama'],
        Spesialis: request_payload['Spesialis']
      )
      status 201  # Berhasil dibuat
      new_dokter.to_hash.to_json
    rescue => e
      halt 500, { error: "Failed to create doctor: #{e.message}" }.to_json
    end
  end

# Get a doctor by ID
get '/dokter/:id' do
  content_type :json
  dokter = Dokter[params[:id].to_i]
  if dokter
    dokter.to_hash.to_json
  else
    status 404
    { error: 'Doctor not found' }.to_json
  end
end
