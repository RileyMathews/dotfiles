import {execSync} from "child_process"

export const TmuxNotify = async () => {
  const renameCurrentOpencodeWindow = (name: string) => {
    const pane = process.env.TMUX_PANE
    if (!pane) return

    const windowId = execSync(`tmux display-message -p -t "${pane}" '#{window_id}'`, {
      encoding: "utf8"
    }).trim()

    execSync(`tmux rename-window -t "${windowId}" "${name}"`)
  }

  return {
    "chat.message": async () => {
      renameCurrentOpencodeWindow(" working")
    },
    event: async ({event}) => {
      if (event.type === "session.idle") {
        renameCurrentOpencodeWindow(" opencode")
      }
    }
  }
}
