import * as React from "react"

const CloseIcon = (props) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    width={24}
    height={24}
    fill="none"
    {...props}
  >
    <path
      stroke="#000"
      strokeLinecap="round"
      strokeWidth={1.5}
      d="M8 15.998 16 8M8 8l8 7.998"
      opacity={0.5}
    />
  </svg>
)

export default CloseIcon