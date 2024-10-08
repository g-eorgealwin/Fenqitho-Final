from flask import Flask, request, jsonify
from transformers import GPT2LMHeadModel, GPT2Tokenizer
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Load the model and tokenizer
model_name = "gpt2"
model = GPT2LMHeadModel.from_pretrained(model_name)
tokenizer = GPT2Tokenizer.from_pretrained(model_name)

@app.route('/generate_lyrics', methods=['POST'])
def generate_lyrics():
    data = request.get_json()
    description = data.get('description')
    genre = data.get('genre')  # Get the genre from the request

    print(f"Received description: {description} with genre: {genre}")  # Log description and genre

    if description:
        # Adjust the prompt to include genre
        prompt = f"Write a {genre} song about: {description}" if genre else f"Write a song about: {description}"
        inputs = tokenizer.encode(prompt, return_tensors='pt')
        outputs = model.generate(inputs, max_length=200, num_return_sequences=1, no_repeat_ngram_size=2)

        generated_lyrics = tokenizer.decode(outputs[0], skip_special_tokens=True)
        print(f"Generated Lyrics: {generated_lyrics}")  # Log generated lyrics for debugging

        return jsonify({'lyrics': generated_lyrics})
    else:
        return jsonify({'error': 'No description provided'}), 400

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)  # Listen on all network interfaces
