import {execSync} from "child_process"

export const TmuxNotify = async () => {
  return {
    "chat.message": async () => {
      execSync(`tmux rename-window " working"`)
    },
    event: async ({event}) => {
      if (event.type === "session.idle") {
        execSync(`tmux rename-window " opencode"`)
      }
    }
  }
}
