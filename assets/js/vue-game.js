import Vue from 'vue'
import { Socket, Presence } from 'phoenix'

const gameContainer = document.querySelector('#game-container')

if (gameContainer) {

  new Vue({
    el: '#game-container',
    data: {
      squares: [],
      scores: {},
      winner: null,
      messages: [],
      players: [],
      chatMessage: '',
      error: ''
    },
    methods: {
      squareStyle(square) {
        const player = square.marked_by
        return player ? { backgroundColor: player.color } : { }
      },
      sendMark(square) {
        if (!square.marked_by) {
          this.channel.push('mark_square', { phrase: square.phrase })
        }
      },
      sendChat(event) {
        if (this.chatMessage) {
          this.channel.push('new_chat_message', { body: this.chatMessage })
          this.chatMessage = ''
        }
      },
      joinChannel(authToken, gameName) {
        const socket = new Socket('/socket', { params: { token: authToken } })

        socket.connect()

        this.channel = socket.channel(`games:${gameName}`, {})

        this.channel.on('game_summary', summary => {
          this.squares = summary.squares
          this.scores = summary.scores
          this.winner = summary.winner
          this.players = this.toPlayers(this.presences)
        })

        this.presences = {}

        this.channel.on('presence_state', state => {
          this.presences = Presence.syncState(this.presences, state)
          this.players = this.toPlayers(this.presences)
        })

        this.channel.on('presence_diff', diff => {
          this.presences = Presence.syncDiff(this.presences, diff)
          this.players = this.toPlayers(this.presences)
        })

        this.channel.on('new_chat_message', message => {
          this.messages.push(message)
        })

        this.channel.join()
          .receive('ok', response => {
            console.log(`Joined ${gameName} 😊`, response)
          })
          .receive("error", response => {
            this.error = `Joining ${gameName} failed 🙁`
            console.log(this.error, response)
          })
      },
      toPlayers(presences) {
        const listBy = (name, { metas: [first, ...rest] }) => {
          const { score, marked } = this.scores[name] || { score: 0, marked: 0 }
          return { name, color: first.color, score, marked }
        }

        return Presence.list(presences, listBy)
      },
      score(player) {
        return `
          ${player.score} (
            ${player.marked} square${player.marked == 1 ? '' : 's'}
          )
        `
      }
    },
    mounted() {
      const { authToken, gameName } = this.$el.dataset
      this.joinChannel(authToken, gameName)
    },
    watch: {
      messages(newValue, oldValue) {
        this.$nextTick(() => {
          // DOM is now updated
          const messageList = this.$refs.messages
          messageList.scrollTop = messageList.scrollHeight
        })
      }
    }
  })

}
