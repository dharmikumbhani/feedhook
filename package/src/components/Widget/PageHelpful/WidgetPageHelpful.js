import '../../../css/styles.css'
import CloseButton from '../../CloseButton/CloseButton'
import Button from '../../Button/Button'
import ModalHeading from '../../ModalHeading/ModalHeading'
import Footer from '../../Footer/Footer'

export default function WidgetPageHelpful(props) {
  return (
    <>
    <div className='widget-container'>
        <CloseButton />
        <ModalHeading heading="Is this page helpful?" />
        <div class="flex-horizontal buttons-container">
            <Button onClickButton={()=> {console.log('Click')}} buttonTitle="Yes" />
            <Button onClickButton={()=> {console.log('Click')}} buttonTitle="No" />
        </div>
        <Footer />
    </div>
    </>
  )
}