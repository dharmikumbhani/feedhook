import Image from 'next/image'

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
        </div>
    </nav>
    </>
  )
}