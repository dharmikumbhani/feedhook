import { useEffect } from 'react'
import '../../css/styles.css'
import angryIconPath from '../../assets/angry-icon.png'
import sadIconPath from '../../assets/sad-icon.png'
import neutralIconPath from '../../assets/neutral-icon.png'
import happyIconPath from '../../assets/happy-icon.png'
import struckIconPath from '../../assets/struck-icon.png'

export default function EmojiButton(props) {
  const mappingEmotionToEmojiPath = {
    angry: {path: angryIconPath,},
    sad: {path: sadIconPath},
    neutral: {path: neutralIconPath},
    happy: {path: happyIconPath},
    struck: {path: struckIconPath}
  }
  return (
    <>
    <button onClick={props.onClickButtonFunction} className="emoji-button" type="submit">
        <img src={mappingEmotionToEmojiPath[props.emotion].path} />
    </button>
    </>
  )
}