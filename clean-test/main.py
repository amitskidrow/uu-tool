#!/usr/bin/env python3
import http.server
import socketserver
import json
import random
import urllib.parse
import sys
from datetime import datetime

class RandomHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path.startswith('/random'):
            # Parse query parameters
            parsed = urllib.parse.urlparse(self.path)
            params = urllib.parse.parse_qs(parsed.query)
            
            min_val = int(params.get('min', [1])[0])
            max_val = int(params.get('max', [100])[0])
            
            result = {
                'random_number': random.randint(min_val, max_val),
                'range': {'min': min_val, 'max': max_val},
                'timestamp': datetime.now().isoformat()
            }
            
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps(result).encode())
            
        elif self.path == '/health':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({'status': 'healthy'}).encode())
            
        else:
            self.send_response(404)
            self.end_headers()

if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
    print(f"Starting random number service on port {port}")
    
    with socketserver.TCPServer(("", port), RandomHandler) as httpd:
        print(f"Server running at http://localhost:{port}")
        print(f"Endpoints: /random, /random?min=X&max=Y, /health")
        httpd.serve_forever()