import Image from 'next/image'
import {ConnectButton} from '@rainbow-me/rainbowkit'

export default function NavBar() {
  return (
    <>
    <nav className='flex-row '>
        <div className="logo-container">
            <a href='/#'>
            <Image
              src="/feedhook.svg"
              alt="Vercel Logo"
              width={200}
              height={100}
              priority
            />
            </a>
        </div>
        <div className="user-loggedIn">
          <ConnectButton chainStatus="icon" showBalance={false} />
        </div>
    </nav>
    </>
  )
}