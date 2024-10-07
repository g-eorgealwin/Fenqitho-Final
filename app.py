from flask import Flask, request, jsonify
from transformers import GPT2LMHeadModel, GPT2Tokenizer
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Load the model and tokenizer
model_name = "gpt2"  # You can use 'gpt2-medium' or 'gpt2-large' if needed
model = GPT2LMHeadModel.from_pretrained(model_name)
tokenizer = GPT2Tokenizer.from_pretrained(model_name)

@app.route('/generate_lyrics', methods=['POST'])
def generate_lyrics():
    data = request.get_json()
    description = data.get('description')

    print(f"Received description: {description}")  # Log incoming description for debugging

    if description:
        # Encode the description and generate lyrics
        inputs = tokenizer.encode(f"Write a song about: {description}", return_tensors='pt')
        outputs = model.generate(inputs, max_length=500, num_return_sequences=1, no_repeat_ngram_size=2)

        generated_lyrics = tokenizer.decode(outputs[0], skip_special_tokens=True)
        print(f"Generated Lyrics: {generated_lyrics}")  # Log generated lyrics for debugging

        return jsonify({'lyrics': generated_lyrics})
    else:
        return jsonify({'error': 'No description provided'}), 400

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)  # Listen on all network interfaces
