require 'sinatra'
require 'json'
require 'sequel'

# Jalur ke file database SQLite
db_path = 'C:/Users/bayyi/dokter.db'

# Menghubungkan ke database SQLite
DB = Sequel.connect(adapter: 'sqlite', database: db_path)

# Model untuk Dokter
class Dokter < Sequel::Model(:dokter)  # Pastikan nama tabel di database adalah 'dokter'
end

# Endpoint untuk memeriksa koneksi database
get '/test_db' do
  content_type :json
  begin
    DB.run('SELECT 1')  # Menguji koneksi dengan menjalankan query sederhana
    { message: "Database connection is working." }.to_json
  rescue => e
    { error: "Database connection failed: #{e.message}" }.to_json
  end
end

# Endpoint untuk mengambil semua dokter
get '/dokter' do
  content_type :json
  dokter_data = Dokter.all

  if dokter_data.empty?
    { error: "No doctors found in the database." }.to_json
  else
    dokter_data.map(&:to_hash).to_json
  end
end

# Endpoint untuk menambahkan dokter baru
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

# Endpoint untuk mendapatkan dokter berdasarkan ID
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

# Jalankan server Sinatra
set :port, 4567
