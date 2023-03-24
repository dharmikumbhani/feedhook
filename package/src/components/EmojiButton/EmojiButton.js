import '../../css/styles.css'
import angryIconPath from '../../assets/angry-icon.png'
import neutralIconPath from '../../assets/neutral-icon.png'
import sadIconPath from '../../assets/sad-icon.png'
import smileIconPath from '../../assets/smile-icon.png'
import struckIconPath from '../../assets/struck-icon.png'

export default function EmojiButton(props) {
  return (
    <>
    <button onClick={props.onClickButton} className="" type="submit">
        <img src={angryIconPath} />
        <img src={sadIconPath} />
        <img src={neutralIconPath} />
        <img src={smileIconPath} />
        <img src={struckIconPath} />
    </button>
    </>
  )
}