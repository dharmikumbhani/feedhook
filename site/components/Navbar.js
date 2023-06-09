import Image from 'next/image'
import { useEffect } from 'react'
import {ConnectButton} from '@rainbow-me/rainbowkit'
import {useAccount} from 'wagmi'
import Link from 'next/link'

export default function NavBar(props) {
  return (
    <>
    <nav className='flex-row '>
        <div className="logo-container">
            <Link href='/#'>
            <Image
              src="/feedhook.svg"
              alt="Vercel Logo"
              width={200}
              height={100}
              priority
            />
            </Link>
        </div>
        <div className="user-loggedIn">
          { props.isConnected ? (
            <ConnectButton chainStatus="icon" showBalance={false} />
          ) : (
            <></>
          )}
        </div>
    </nav>
    </>
  )
}