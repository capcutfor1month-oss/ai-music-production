# What to Fix — Logic & UX
> Things to sort before moving forward. Update as fixed.

---

## 🔴 Broken / Not Working

| # | What | Where | Issue |
|---|---|---|---|
| 1 | NotebookLM response formatting | Float chat → NLM bubble | `Answer:` prefix, `Conversation: uuid` footer, `[1][2]` citations all showing raw. Bold `**text**` not rendering. Bullets `*` not converting. |
| 2 | fLive button | Float chat toolbar | Toggles state but doesn't pull real Ableton session data. Should fetch track list, BPM, active clips via bridge when ON. |
| 3 | Analyze button | Float chat toolbar | File picker works but result never shows in chat. Should run file through bridge → audio-analyzer → show key/BPM/LUFS as a response bubble. |
| 4 | Auto source routing | Float chat | "Auto" selected → still shows placeholder. Should keyword-detect and route to correct source. |
| 5 | Memory only source | Float chat | No routing logic. Should query Mem0 via bridge. |
| 6 | Source files source | Float chat | No routing logic. Unclear what this should do — define and wire. |

---

## 🟡 UX Needs Polish

| # | What | Where | Issue |
|---|---|---|---|
| 7 | Auto Exec button | Float chat toolbar | Looks visually disabled when OFF (polygon opacity 0.55). Should look clearly clickable, just inactive. |
| 8 | NLM bubble copy button | Float chat | No copy button on NLM response bubbles. Every other message has one. |
| 9 | NLM bubble loading state | Float chat | "Querying your knowledge base…" dot animation — dot color doesn't match NLM blue properly. |
| 10 | Source label reset | Float chat | After closing/reopening chat, source label stays on last selection but should probably reset to Auto. |
| 11 | Chat input placeholder | Float chat | Doesn't update when NotebookLM is selected. Should say "Ask your knowledge base…" |

---

## 🔵 Empty / Not Built Yet

| # | What | Where | Notes |
|---|---|---|---|
| 12 | Session tab | Panel → Session | Completely empty. Needs: session name, BPM, key, track count, active clips. |
| 13 | Tasks tab | Panel → Tasks | Completely empty. Needs: task list, status, run/stop buttons. |
| 14 | Chat tab (panel) | Panel → Chat | Still uses old placeholder sendMessage() — not routed like float chat. |
| 15 | Token counter | Float chat | Show live estimated token count in footer. Needs Claude API to be accurate but can estimate. |

---

## ✅ Fixed (keep for reference)

| # | What | Fixed |
|---|---|---|
| F1 | Source dropdown not opening | Moved out of float-chat (backdrop-filter broke fixed positioning) |
| F2 | Notch disappearing on dropdown click | Added guard in scheduleHidePanel + mouseenter on dropdown |
| F3 | NotebookLM wired to chat | Routes when source = NotebookLM, auto-converts to structured template |
| F4 | Integration status polling | Real ping every 8s, live dots |
| F5 | Connection setup page | 4-step guide, path config, auto-detect |
