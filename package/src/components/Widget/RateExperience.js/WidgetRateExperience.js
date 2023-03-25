import '../../../css/styles.css'
import CloseButton from '../../CloseButton/CloseButton'
import Button from '../../Button/Button'
import ModalHeading from '../../ModalHeading/ModalHeading'
import Footer from '../../Footer/Footer'
import EmojiButton from '../../EmojiButton/EmojiButton'

export default function WidgetRateExperience(props) {
    const arrayOfEmotions = [
        "angry",
        "sad",
        "neutral",
        "happy",
        "struck"
    ]
  return (
    <>
    <div className='widget-container'>
        <CloseButton />
        <ModalHeading heading="Rate Your Experience" />
        <div className='flex-horizontal buttons-container'>
            {arrayOfEmotions.map((value, key) =>
                (
                    <EmojiButton key={key} emotion={value} />
                )
            )}
        </div>
        <Footer />
    </div>
    </>
  )
}