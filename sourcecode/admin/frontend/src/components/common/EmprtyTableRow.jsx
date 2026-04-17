const EmprtyTableRow = ({ limit = 10, data = [], columns = [], noDataLebel, noDataLabel, paddingClass = '' }) => {
  const emptyRows = Math.max(0, limit - data.length)

  if (emptyRows === 0) return null

  const messageRowIndex = Math.floor(emptyRows / 2)
  const message = noDataLabel || noDataLebel || 'No Data Found'

  return [...Array(emptyRows)].map((_, index) => (
    <tr key={`empty-row-${index}`} className='border-b'>
      <td colSpan={columns.length || 25} className={`py-4 text-center ${paddingClass}`.trim()}>
        {index === messageRowIndex && data.length === 0 ? (
          <div className='font-medium text-gray-500'>{message}</div>
        ) : (
          ''
        )}
      </td>
    </tr>
  ))
}

export default EmprtyTableRow
