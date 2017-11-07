#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#
#  Showdown Exporter v2 for Pokémon Essentials by Cilerba, rewritten by M3rein
#
#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
SDWN_ALOLAN = { # What forms of what species are seen as Alolan.
  :RATTATA   => 1,
  :RATICATE  => 1,
  :RAICHU	=> 1,
  :SANDSHREW => 1,
  :SANDSLASH => 1,
  :VULPIX	=> 1,
  :NINETALES => 1,
  :DIGLETT   => 1,
  :DUGTRIO   => 1,
  :MEOWTH	=> 1,
  :PERSIAN   => 1,
  :GEODUDE   => 1,
  :GRAVELER  => 1,
  :GOLEM	 => 1,
  :GRIMER	=> 1,
  :MUK	   => 1,
  :EXEGGUTOR => 1,
  :MAROWAK   => 1
}
 
SDWN_MOVES = { # Turns the left move into the right move. This for compatibility with custom moves.
  :CUSTOM1 => :TACKLE,
  :CUSTOM2 => :POUND,
  :CUSTOM3 => :SLAM
}
 
 
def getShowdownName(p)
  for key in SDWN_ALOLAN.keys
	if p.species == getConst(PBSpecies,key) && p.form == SDWN_ALOLAN[key]
	  return "#{PBSpecies.getName(p.species)}-Alola"
	end
  end
  return PBSpecies.getName(p.species)
end
 
def getShowdownMove(m)
  for key in SDWN_MOVES.keys
	if m.id == getConst(PBMoves,key)
	  return PBMoves.getName(getConst(PBMoves,SDWN_MOVES[key]))
	end
  end
  return PBMoves.getName(m.id)
end
 
def pbShowdown
  ret = ""
  for i in 0...$Trainer.party.size
	p = $Trainer.party[i]
	next if !p || p.isEgg?
	if p.name != "" && p.name != PBSpecies.getName(p.species)
	  ret += "#{p.name} (#{getShowdownName(p)}) "
	else
	  ret += "#{getShowdownName(p)} "
	end
	ret += p.gender == 0 ? "(M) " : p.gender == 1 ? "(F) " : ""
	ret += "@ #{PBItems.getName(p.item)}" if p.item > 0
	ret += "\n"
	ret += "Ability: #{PBAbilities.getName(p.ability)}\n"
	ret += "Level: #{p.level}\n" if p.level < 100
	ret += "Shiny: Yes\n" if p.isShiny?
	ret += "Happiness: #{p.happiness}\n" if p.happiness < 255
	evs = [p.ev[0],p.ev[1],p.ev[2],p.ev[4],p.ev[5],p.ev[3]]
	stats = ["HP", "Atk", "Def", "SpA", "SpD", "Spe"]
	if evs[0] > 0 || evs[1] > 0 || evs[2] > 0 || evs[3] > 0 || evs[4] > 0 || evs[5] > 0
	  ret += "EVs:"
	  for i in 0...6
		ret += " #{evs[i]} #{stats[i]} /" if evs[i] > 0
	  end
	  ret = ret[0, ret.size - 2] + "\n"
	end
	ret += "#{PBNatures.getName(p.nature)} Nature\n"
	ivs = [p.iv[0],p.iv[1],p.iv[2],p.iv[4],p.iv[5],p.iv[3]]
	if ivs[0] < 31 || ivs[1] < 31 || ivs[2] < 31 || ivs[3] < 31 || ivs[4] < 31 || ivs[5] < 31
	  ret += "IVs:"
	  for i in 0...6
		ret += " #{ivs[i]} #{stats[i]} /" if ivs[i] < 31
	  end
	  ret = ret[0, ret.size - 2] + "\n"
	end
	for j in 0...p.moves.size
	  next if !p.moves[j] || p.moves[j].id == 0
	  ret += "- #{getShowdownMove(p.moves[j])}\n"
	end
	ret += "\n"
  end
  file = File.new("showdown.txt", "w+")
  file.write(ret)
  file.close
end