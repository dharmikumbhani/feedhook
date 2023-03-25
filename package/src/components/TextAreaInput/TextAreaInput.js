import '../../css/styles.css'

export default function TextAreaInput(props) {
  return (
    <>
        <textarea onChange={(e)=> {props.setFeedbackText(e.target.value)}} className='text-area-input' type="text" name="myInput" placeholder="Feedback" />
    </>
  )
}