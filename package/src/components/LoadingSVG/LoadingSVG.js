import * as React from "react"

const LoadingSVG = (props) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 100 100"
    xmlSpace="preserve"
    {...props}
  >
    <circle cx={30} cy={50} r={6}>
      <animate
        attributeName="opacity"
        dur="1s"
        values="0;1;0"
        repeatCount="indefinite"
        begin={0.1}
      />
    </circle>
    <circle cx={50} cy={50} r={6}>
      <animate
        attributeName="opacity"
        dur="1s"
        values="0;1;0"
        repeatCount="indefinite"
        begin={0.2}
      />
    </circle>
    <circle cx={70} cy={50} r={6}>
      <animate
        attributeName="opacity"
        dur="1s"
        values="0;1;0"
        repeatCount="indefinite"
        begin={0.3}
      />
    </circle>
  </svg>
)

export default LoadingSVG
