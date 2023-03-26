import * as React from "react"

const CloseIcon = (props) => (
  <>
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
      strokeWidth={2}
      d="M7 17 17 7M7 7l10 10"
      opacity={0.5}
    />
  </svg>
  </>
)

export default CloseIcon