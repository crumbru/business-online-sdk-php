#!/usr/bin/env bash
# Проверка Superpowers для OpenCode и установка для Codex.
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

info() { printf '  %s\n' "$*"; }
fail() { printf 'Ошибка: %s\n' "$*" >&2; exit 1; }

printf '== OpenCode ==\n'
[[ -f opencode.json ]] || fail "в корне нет opencode.json"
if grep -q 'superpowers@git+https://github.com/obra/superpowers.git' opencode.json; then
  info "Superpowers объявлен в opencode.json"
else
  fail "в opencode.json нет superpowers — добавьте plugins из AGENTS.md"
fi

printf '== Codex ==\n'
[[ -f .codex/config.toml ]] || fail "в корне нет .codex/config.toml"
[[ -f .agents/plugins/marketplace.json ]] || fail "нет .agents/plugins/marketplace.json"

if ! command -v codex >/dev/null 2>&1; then
  info "Codex CLI не найден — шаг пропущен"
  printf '\nКонфигурация OpenCode в порядке. Установите Codex и повторите: bash scripts/agent-setup.sh\n'
  exit 0
fi

info "обновляю marketplace"
codex plugin marketplace upgrade >/dev/null 2>&1 || info "marketplace upgrade не удался — продолжаю"

if codex plugin list 2>/dev/null | grep -qi 'superpowers'; then
  info "Superpowers уже установлен"
else
  info "устанавливаю superpowers@crumb-agents"
  if ! codex plugin add superpowers@crumb-agents; then
    fail "не удалось установить автоматически: откройте Codex в этом репозитории (trusted project) и выполните /plugins → Superpowers"
  fi
fi

if codex plugin list 2>/dev/null | grep -qi 'superpowers'; then
  info "Superpowers доступен Codex"
else
  info "плагин установлен, но список Codex его не показывает — проверьте /plugins"
fi

printf '\nГотово. Перезапустите OpenCode/Codex, если они были открыты.\n'
printf 'Проверка: спросите агента «Tell me about your superpowers».\n'
