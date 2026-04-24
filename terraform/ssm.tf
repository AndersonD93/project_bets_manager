resource "aws_ssm_parameter" "world_cup_countries" {
  name        = "/bets-manager/world-cup-2026/countries"
  type        = "StringList"
  value       = join(",", jsondecode(file("${path.module}/templates/parameter_store/paises.json")))
  description = "Lista de países participantes en el Mundial 2026"
  tags        = { Project = var.project }
}

resource "aws_ssm_parameter" "champion_insert_blocked" {
  name        = "/bets-manager/champion/insert-blocked"
  type        = "String"
  value       = "false"
  description = "Bloqueo de creación de campeón por admin"
  tags        = { Project = var.project }

  lifecycle { ignore_changes = [value] }
}

resource "aws_ssm_parameter" "champion_update_blocked" {
  name        = "/bets-manager/champion/update-blocked"
  type        = "String"
  value       = "false"
  description = "Bloqueo de modificación de campeón por admin"
  tags        = { Project = var.project }

  lifecycle { ignore_changes = [value] }
}

resource "aws_ssm_parameter" "tournament_champion" {
  name        = "/bets-manager/champion/tournament-winner"
  type        = "String"
  value       = ""
  description = "Campeón final del torneo seleccionado por el admin (vacío = sin seleccionar)"
  tags        = { Project = var.project }

  lifecycle { ignore_changes = [value] }
}
