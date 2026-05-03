import os
import logging
import requests
from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import Application, CommandHandler, MessageHandler, CallbackQueryHandler, filters

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

TOKEN = os.getenv('8589347109:AAGbY6vymD0r4aokbG452ZxS4uUzjOODb9s')

async def start(update: Update, context):
    await update.message.reply_text(
        f"🎵 Привет! Я музыкальный бот!\n"
        "Отправь мне название песни или исполнителя\n"
        "Команды: /help /history /favorites"
    )

async def search(update: Update, context):
    query = update.message.text
    url = f"https://itunes.apple.com/search?term={query}&limit=5"
    
    try:
        data = requests.get(url).json()
        if data['resultCount'] == 0:
            await update.message.reply_text("Ничего не найдено 😔")
            return
        
        for item in data['results'][:5]:
            text = f"🎵 {item['trackName']}\n👤 {item['artistName']}\n💿 {item['collectionName']}"
            
            keyboard = []
            if 'previewUrl' in item:
                keyboard.append([InlineKeyboardButton("▶️ Превью", url=item['previewUrl'])])
            if 'trackViewUrl' in item:
                keyboard.append([InlineKeyboardButton("🎧 Apple Music", url=item['trackViewUrl'])])
            
            markup = InlineKeyboardMarkup(keyboard) if keyboard else None
            
            if 'artworkUrl100' in item:
                await update.message.reply_photo(item['artworkUrl100'], caption=text, reply_markup=markup)
            else:
                await update.message.reply_text(text, reply_markup=markup)
    except Exception as e:
        await update.message.reply_text("Ошибка поиска 😔")

async def help_cmd(update: Update, context):
    await update.message.reply_text("Просто отправь название песни! Например: Shape of You")

def main():
    app = Application.builder().token(TOKEN).build()
    app.add_handler(CommandHandler("start", start))
    app.add_handler(CommandHandler("help", help_cmd))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, search))
    
    logger.info("Bot started!")
    app.run_polling()

if __name__ == '__main__':
    main()
