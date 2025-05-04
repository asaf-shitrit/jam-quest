extends Node

func get_team_name(team: Globals.Team) -> String:
	match team:
		Globals.Team.A:
			return "A"
		Globals.Team.B:
			return "B"
		_:
			return ""
