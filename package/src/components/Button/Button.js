import '../../css/styles.css'

export default function Button(props) {
  return (
    <>
    <button onClick={props.onClickButton} className="flex-horizontal cta-widget-button" type="submit">
        {props.buttonTitle}
    </button>
    </>
  )
}