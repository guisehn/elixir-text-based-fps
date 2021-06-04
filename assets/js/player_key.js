import { uuid } from 'uuidv4'

const STORAGE_KEY = 'player_key'

export function getPlayerKey() {
  if (!localStorage.getItem(STORAGE_KEY)) {
    localStorage.setItem(STORAGE_KEY, uuid())
  }

  return localStorage.getItem(STORAGE_KEY)
}