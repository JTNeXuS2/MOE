import http.server
import socketserver
import socket
# Тестировать например отсюда https://www.networkcenter.info/tests/portcheck
# Запрос портов у пользователя
http_port = input("Введите номер порта для HTTP и UDP сервера: ")
udp_port = http_port

try:
    HTTP_PORT = int(http_port)
    UDP_PORT = int(udp_port)
except ValueError:
    print("Порты должны быть числами")
    exit()

class CustomHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        # Отправляем пользователю кастомную HTML страницу
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()
        self.wfile.write(b"<html><body><h1>OPENED!</h1></body></html>")
        print(f"Получен GET запрос от {self.client_address[0]}:{self.client_address[1]}")

Handler = CustomHandler

# HTTP сервер
try:
    with socketserver.TCPServer(("0.0.0.0", HTTP_PORT), Handler) as httpd:
        print(f"HTTP сервер запущен на порту {HTTP_PORT}")
        httpd.serve_forever()
except ConnectionResetError:
    print("Ошибка: Удаленный хост принудительно разорвал существующее соединение")

# UDP сервер
udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
udp_socket.bind(("0.0.0.0", UDP_PORT))
print(f"UDP сервер запущен на порту {UDP_PORT}")

while True:
    data, addr = udp_socket.recvfrom(1024)
    print(f"Получено сообщение от {addr}: {data.decode()}")
