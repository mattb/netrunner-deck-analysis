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

ident_ids = cards.select { |c| c['type_code'] == 'identity' and c['faction_code'] == ARGV[0] }.map { |c| c['name'] }

decks.select { |deck| deck['cards'].any? { |k,v| ident_ids.include?(k) } }.map { |deck| deck['cards'].map { |k,v| [k] * v } }.flatten.group_by { |x| x }.map { |x,xs| [x,xs.size] }.map { |id, count| [card_idx[id]['label'], count] }.sort_by { |label, count| count }.reverse.slice(0, 50).each { |label, count| puts ["*" * (count/30), label].join(" ") }
