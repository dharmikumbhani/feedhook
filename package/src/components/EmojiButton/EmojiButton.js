import { useEffect } from 'react'
import '../../css/styles.css'
import angryIconPath from '../../assets/angry-icon.png'
import sadIconPath from '../../assets/sad-icon.png'
import neutralIconPath from '../../assets/neutral-icon.png'
import happyIconPath from '../../assets/happy-icon.png'
import struckIconPath from '../../assets/struck-icon.png'

export default function xEmojiButton(props) {
  const mappingEmotionToEmojiPath = {
    angry: {
      value: -2,
      path: angryIconPath,
    },
    sad: {
      value: -1,
      path: sadIconPath,
    },
    neutral: {
      value: 0,
      path: neutralIconPath,
    },
    happy: {
      value: 1,
      path: happyIconPath,
    },
    struck: {
      value: 1,
      path: struckIconPath,
    }
  }
  useEffect(() => {
  }, [])
  return (
    <>
    <button onClick={props.onClickButton} className="emoji-button" type="submit">
        <img src={mappingEmotionToEmojiPath[props.emotion].path} />
    </button>
    </>
  )
}