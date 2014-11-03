# Encoding: utf-8
require 'json'

cards = JSON.parse(open("cards.json").read)
decks = Dir.glob("2*.json").map { |f| JSON.parse(open(f).read) }.flatten

card_idx = {}
cards.each { |card|
  card["name"] = card["code"]
  card["label"] = card["title"]
  card.delete("code")
  card.delete("title")
  card["count"] = 0
  card_idx[card["name"]] = card
}

decks.each { |deck|
  deck['cards'].each { |card, count|
    card_idx[card]['count'] += count
  }
}

card = cards.first
keys = ["name", "label"] + (card.keys - ["name", "label"])

cards.sort_by { |c| c['count'] }.select { |c| c['type_code'] == 'identity' }.each { |card| puts ["*" * (card['count']/10), card['label']].join(" ") }
