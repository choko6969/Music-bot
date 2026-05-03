import telebot
import requests

TOKEN = 'YOUR_BOT_TOKEN'
bot = telebot.TeleBot(TOKEN)

@bot.message_handler(commands=['start'])
def start(message):
    bot.reply_to(message, "Привет! Отправь мне название песни 🎵")

@bot.message_handler(content_types=['text'])
def search_music(message):
    query = message.text
    url = f"https://itunes.apple.com/search?term={query}&limit=3"
    
    try:
        response = requests.get(url)
        data = response.json()
        
        if data['resultCount'] > 0:
            for item in data['results'][:3]:
                text = f"🎵 {item['trackName']}\n👤 {item['artistName']}"
                if 'previewUrl' in item:
                    bot.send_message(message.chat.id, text)
                    bot.send_audio(message.chat.id, item['previewUrl'])
                else:
                    bot.send_message(message.chat.id, text)
        else:
            bot.reply_to(message, "Ничего не найдено 😔")
    except:
        bot.reply_to(message, "Ошибка поиска")

bot.polling(none_stop=True)



























