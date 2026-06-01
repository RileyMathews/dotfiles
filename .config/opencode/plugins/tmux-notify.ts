import {execSync} from "child_process"

export const TmuxNotify = async () => {
  const WORKING_ICON = ""
  const DONE_ICON = ""

  const setWindowIcon = (icon: string) => {
    const pane = process.env.TMUX_PANE
    if (!pane) return

    const windowId = execSync(`tmux display-message -p -t "${pane}" '#{window_id}'`, {
      encoding: "utf8"
    }).trim()

    const currentName = execSync(`tmux display-message -p -t "${windowId}" '#{window_name}'`, {
      encoding: "utf8"
    }).trim()

    let baseName = currentName
    if (currentName.endsWith(WORKING_ICON)) {
      baseName = currentName.slice(0, -WORKING_ICON.length)
    } else if (currentName.endsWith(DONE_ICON)) {
      baseName = currentName.slice(0, -DONE_ICON.length)
    }

    execSync(`tmux rename-window -t "${windowId}" "${baseName}${icon}"`)
  }

  return {
    "chat.message": async () => {
      setWindowIcon(WORKING_ICON)
    },
    event: async ({event}) => {
      if (event.type === "session.idle") {
        setWindowIcon(DONE_ICON)
      }
    }
  }
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
