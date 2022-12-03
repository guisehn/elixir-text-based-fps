import { v4 as uuid } from 'uuid'

const STORAGE_KEY = 'player_key'

export function getPlayerKey() {
  if (!localStorage.getItem(STORAGE_KEY)) {
    localStorage.setItem(STORAGE_KEY, uuid())
  }

  return localStorage.getItem(STORAGE_KEY)
}