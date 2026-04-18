const BrandName = ({
  text = 'Notisboard',
  component = 'span',
  className,
  style,
  baseColor = '#FBD100',
  highlightColor = '#000000',
  ...props
}) => {
  const Component = component
  const value = typeof text === 'string' && text.length > 0 ? text : 'Notisboard'
  const matches = [...value.matchAll(/[oO]/g)]
  const highlightIndex = matches.length >= 2 ? matches[1].index : matches[0]?.index ?? -1

  if (highlightIndex === -1) {
    return (
      <Component className={className} style={style} {...props}>
        <span style={{ color: baseColor }}>{value}</span>
      </Component>
    )
  }

  const before = value.slice(0, highlightIndex)
  const highlighted = value[highlightIndex]
  const after = value.slice(highlightIndex + 1)

  return (
    <Component className={className} style={style} {...props}>
      {before && <span style={{ color: baseColor }}>{before}</span>}
      <span style={{ color: highlightColor }}>{highlighted}</span>
      {after && <span style={{ color: baseColor }}>{after}</span>}
    </Component>
  )
}

export default BrandName
