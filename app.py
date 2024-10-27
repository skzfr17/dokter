from flask import Flask, request, jsonify
import sqlite3

app = Flask(__name__)

# Konfigurasi database
db_config = 'C:/Users/bayyi/dokter.db'  # Ganti dengan nama file database SQLite Anda

@app.route('/dokter', methods=['GET'])  # Endpoint yang mendukung metode GET
def get_dokter():
    conn = None
    try:
        conn = sqlite3.connect(db_config)
        cursor = conn.cursor()

        sql = 'SELECT * FROM dokter'
        cursor.execute(sql)
        result = cursor.fetchall()

        # Mengonversi hasil menjadi dictionary
        columns = [column[0] for column in cursor.description]
        result_dict = [dict(zip(columns, row)) for row in result]

        return jsonify(result_dict)

    except sqlite3.Error as err:
        return jsonify({"error": str(err)}), 500

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

# POST request untuk menambahkan data
@app.route('/dokter', methods=['POST'])
def add_dokter():
    data = request.json
    conn = sqlite3.connect(db_config)
    cursor = conn.cursor()
    cursor.execute("INSERT INTO dokter (nama, spesialis) VALUES (?, ?)",
                   (data['nama'], data['spesialis']))
    conn.commit()
    cursor.close()
    conn.close()
    return jsonify({'message': 'dokter added successfully'}), 201

# PUT request untuk memperbarui data
@app.route('/dokter/<int:id>', methods=['PUT'])
def update_dokter(id):
    data = request.get_json()
    nama = data.get("nama")
    spesialis = data.get("spesialis")

    try:
        conn = sqlite3.connect(db_config)
        cursor = conn.cursor()
        cursor.execute("UPDATE dokter SET nama = ?, spesialis = ? WHERE id = ?", (nama, spesialis, id))
        conn.commit()
        return jsonify({"message": "Data dokter berhasil diperbarui"}), 200
    except sqlite3.Error as err:
        return jsonify({"error": str(err)}), 500
    finally:
        cursor.close()
        conn.close()


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=1111)