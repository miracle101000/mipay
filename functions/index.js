const functions = require('firebase-functions')
const admin = require('firebase-admin')
admin.initializeApp()

exports.sendNotification = functions.firestore
  .document('Transactions/{transactionID}')
  .onCreate((snap, context) => {
    console.log('----------------start function--------------------')

    const doc = snap.data()
    console.log(doc)

    const idFrom = doc.idFrom
    const idTo = doc.idTo
    const amount =  doc.amount
     const contentMessage = doc.content

    // Get push token user to (receive)
    admin
      .firestore()
      .collection('users')
      .where('id', '==', idTo)
      .get()
      .then(querySnapshot => {
        querySnapshot.forEach(userTo => {
          console.log(`Found user to: ${userTo.data().username}`)
          if (userTo.data().pushToken && userTo.data().sendTo !== idFrom || userTo.data().pushToken && userTo.data().sendTo !== '') {
            // Get info user from (sent)
            admin
              .firestore()
              .collection('users')
              .where('id', '==', idFrom)
              .get()
              .then(querySnapshot2 => {
                querySnapshot2.forEach(userFrom => {
                  console.log(`Found user from: ${userFrom.data().username}`)
                  const payload = {
                    notification: {
                      title: `MiPay`,
                      body: `${userFrom.data().username} ${contentMessage} ₦${amount}`,
                      clickAction: 'FLUTTER_NOTIFICATION_CLICK',
                      badge: '1',
                      sound: 'default'
                    }
                  }
                  // Let push to the target device
                  admin
                    .messaging()
                    .sendToDevice(userTo.data().pushToken, payload)
                    .then(response => {
                      console.log('Successfully sent message:', response)
                        return null
                    })
                    .catch(error => {
                      console.log('Error sending message:', error)
                    })
                })
                  return null
              }).catch(error3 => {
               console.log('Can not find pushToken target user')
              })
          } else {
            console.log('Can not find pushToken target user')
          }
        })
          return null
      }).catch(error2 => {
        console.log('Can not find pushToken target user')
      })
    return null
  })