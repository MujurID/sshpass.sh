#!/system/bin/sh
#
# sshpass.sh - versi yang kompatibel dengan Android sh
# Berdasarkan skrip dari https://github.com/huan/sshpass.sh
#

# Perangkap sinyal untuk membersihkan proses ssh jika skrip diinterupsi
trap 'trap - INT; kill -TERM $SSH_PID 2>/dev/null; kill -INT $$' INT

# Bagian ini dijalankan oleh ssh untuk mendapatkan kata sandi
if [ -n "$SSH_ASKPASS_PASSWORD" ]; then
    # Mengganti 'cat <<<' (bash) dengan 'echo' (sh)
    echo "$SSH_ASKPASS_PASSWORD"

# Bagian ini dijalankan saat Anda pertama kali memanggil skrip
elif [ $# -lt 1 ]; then
    echo "Penggunaan: echo password | $0 <perintah ssh>" >&2
    exit 1
else
    # Membaca kata sandi dari input (melalui pipe)
    read SSH_ASKPASS_PASSWORD

    # Mengekspor variabel agar ssh dapat melihatnya
    export SSH_ASKPASS=$0
    export SSH_ASKPASS_PASSWORD

    # SSH_ASKPASS memerlukan variabel DISPLAY, jadi kita buat dummy jika tidak ada
    if [ -z "$DISPLAY" ]; then
        export DISPLAY=dummydisplay:0
    fi

    # Menjalankan ssh di sesi baru agar terlepas dari terminal
    # dan memungkinkannya memanggil kembali skrip ini untuk kata sandi
    setsid "$@" </dev/null &
    SSH_PID=$!
    wait $SSH_PID
fi
