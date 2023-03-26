import '../../css/styles.css'
import FeedhookLogo from '../Icons/FeedhookLogo'

export default function Footer() {
  return (
    <>
    <div className='flex-horizontal footer'>
        <div className="feedhook-logo-container"><FeedhookLogo /></div>
        <p className='footer-text'>Widget by Feedhook</p>
    </div>
    </>
  )
}