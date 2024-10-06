from flask import Flask, request, jsonify
import os
import requests
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

app = Flask(__name__)

# Load your Mistral API key from the environment variable
MISTRAL_API_KEY = os.getenv('MISTRAL_API_KEY')

@app.route('/generate_lyrics', methods=['POST'])
def generate_lyrics():
    data = request.get_json()
    description = data.get('description')

    if description:
        # Call the Mistral API to generate lyrics
        headers = {
            'Authorization': f'Bearer {MISTRAL_API_KEY}',
            'Content-Type': 'application/json'
        }

        prompt = f"Write a song based on the following description: {description}"
        payload = {
            "prompt": prompt,
            "max_tokens": 100,  # Adjust as needed
            "temperature": 0.7   # Adjust creativity level
        }

        response = requests.post('https://api.mistral.ai/v1/generate', headers=headers, json=payload)

        if response.status_code == 200:
            generated_lyrics = response.json().get('generated_text')
            return jsonify({'lyrics': generated_lyrics})
        else:
            return jsonify({'error': 'Failed to generate lyrics from Mistral API'}), 500
    else:
        return jsonify({'error': 'No description provided'}), 400

if __name__ == '__main__':
    app.run(debug=True)
