import { Socket } from "phoenix"
import { default as AnsiUp } from "ansi_up"

import { getPlayerKey } from "./player_key"
import { UP_ARROW_KEYCODE, DOWN_ARROW_KEYCODE } from "./key_codes"
const MAX_COMMAND_LOG_SIZE = 50

class CLI {
  constructor() {
    this.playerKey = getPlayerKey()
    this.commandLog = []
    this.commandLogPosition = 0
    this.socket = new Socket("/socket")
    this.form = document.forms.form
    this.input = this.form.elements.input
    this.terminalContent = document.querySelector("#terminal-content")
  }

  init() {
    this.connect()
    this.socket.onMessage(msg => this.messageReceived(msg))
    this.initForm()
  }

  initForm() {
    this.form.addEventListener("submit", e => this.submit(e))
    this.input.addEventListener("blur", () => this.input.focus())
    this.input.addEventListener("keydown", e => this.handleKeydown(e))
  }

  handleKeydown(e) {
    switch (e.which) {
      case UP_ARROW_KEYCODE:
        this.handleUpArrowKey()
        e.preventDefault()
        break

      case DOWN_ARROW_KEYCODE:
        this.handleDownArrowKey()
        e.preventDefault()
        break
    }
  }

  submit(e) {
    e.preventDefault()

    const value = this.input.value.trim()

    if (value === "clear") {
      this.clearTerminal()
      this.addToCommandLog(value)
    } else {
      if (value !== "") {
        this.channel.push(value)
        this.addToCommandLog(value)
      }
      this.appendToTerminal("> " + value)
    }

    this.input.value = ""
    this.input.focus()
  }

  addToCommandLog(value) {
    this.commandLogPosition = this.commandLog.push(value)
    if (this.commandLog.length > MAX_COMMAND_LOG_SIZE) {
      this.commandLog.splice(0, this.commandLog.length - MAX_COMMAND_LOG_SIZE)
      this.commandLogPosition = MAX_COMMAND_LOG_SIZE
    }
  }

  connect() {
    this.socket.connect({ "key": this.playerKey })
    this.socket.onOpen(() => console.log("socket open!"))
    this.socket.onClose(() => console.log("socket: connection closed!"))

    this.channel = this.socket.channel("game:" + this.playerKey, {})
    this.channel.join()
      .receive("ok", resp => { console.log("Joined channel successfully", resp) })
      .receive("error", resp => { console.log("Unable to join", resp) })
  }

  messageReceived({ event, payload }) {
    switch (event) {
      case "phx_reply":
        return this.replyReceived(payload)
      case "welcome":
      case "notification":
        return this.appendToTerminal(payload.message)
    }
  }

  replyReceived(payload) {
    const { status, response } = payload
    if (response.message) {
      this.appendToTerminal(status === "error" ? this.red(response.message) : response.message)
    }
  }

  red(message) {
    message = message.replace(/\u001B\[0m/g, "\u001b[31m")
    return `\u001b[31m${message}\u001b[0m`
  }

  appendToTerminal(text) {
    this.terminalContent.innerHTML += this.applyColors(text) + "\n"
    this.scrollToBottom()
  }

  scrollToBottom() {
    const cli = this.terminalContent.parentElement
    setTimeout(() => {
      cli.scrollTop = cli.scrollHeight
    }, 1)
  }

  clearTerminal() {
    this.terminalContent.innerHTML = ""
  }

  applyColors(text) {
    if (!this.ansiUp) {
      this.ansiUp = new AnsiUp({ use_classes: true })
      this.ansiUp.use_classes = true
    }
    return this.ansiUp.ansi_to_html(text)
  }

  handleUpArrowKey () {
    if (this.commandLogPosition > 0) {
      this.commandLogPosition--
      this.input.value = this.commandLog[this.commandLogPosition]
    }
  }

  handleDownArrowKey () {
    if (this.commandLogPosition < this.commandLog.length - 1) {
      this.commandLogPosition++
      this.input.value = this.commandLog[this.commandLogPosition]
    } else {
      this.commandLogPosition = this.commandLog.length
      this.input.value = ''
    }
  }
}

new CLI().init()