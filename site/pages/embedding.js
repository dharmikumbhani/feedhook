import Head from 'next/head'
import Image from 'next/image'
import { Button } from "@tremor/react";
import { ArrowRightIcon, GlobeAltIcon, RefreshIcon, SearchIcon } from "@heroicons/react/outline";
import NavBar from '@/components/Navbar';
import { TextInput } from '@tremor/react';

export default function Embedding() {
  return (
    <>
      <Head>
        <title>Feedhook Embedding</title>
        <meta name="description" content="Generated by Feedhook" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <link rel="icon" href="/favicon.ico" />
      </Head>
      <NavBar />
      <main className='main'>
        <div>
            <p>Congratulations! on setting up the widget</p>
        </div>
      </main>
    </>
  )
}
