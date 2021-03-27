const functions = require('firebase-functions')
const admin = require('firebase-admin')

admin.initializeApp()

const requisitionsRef = admin.firestore().collection('requisitions');
const mailRef = admin.firestore().collection('mail');
var numberDoc = 0;

// Requisitions
exports.createRequisition = functions.firestore
    .document('requisitions/{requisitionId}')
    .onCreate((snap, context) => {
        admin.messaging().sendToTopic('requisition_create', {
            notification: {
                title: 'Nova requisição de ' + snap.data().nameUserRequested,
                body: 'Descrição: ' + snap.data().description,
                clickAction: 'FLUTTER_NOTIFICATION_CLICK',
            }
        })
        // var numberDoc = 0;
        requisitionsRef.orderBy('createdAt').get().then(querySnapshot => {
            querySnapshot.forEach(doc => {
                if (doc.data().number == null) {
                    numberDoc += 1;
                    const number = numberDoc;
                    doc.ref.set({ number }, { merge: true });
                }
                if (doc.data().number > numberDoc) {
                    numberDoc = doc.data().number;
                }
            });
            return;
        })
        // .then((_) => {
        //     functions.logger.log('New Number', context.params.documentId, numberDoc);
        //     const number = numberDoc + 1;
        //     return snap.ref.set({ number }, { merge: true });
        // })
    })

exports.updateRequisition = functions.firestore
    .document('requisitions/{requisitionId}')
    .onUpdate((change, context) => {
        if (change.after.data().status != 'PENDENTE')
            admin.messaging().sendToTopic('requisition_update_' + change.after.data().idUserRequested, {
                notification: {
                    title: 'Status: ' + change.after.data().status + ' por ' + change.after.data().solvedByName,
                    body: 'Descrição: ' + change.after.data().description,
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK'
                }
            })
        if (change.after.data().status == 'APROVADO' && change.after.data().emailProvider != '' && change.after.data().number != null) {

            let options = {
                dateStyle: ('short'),
                timeStyle: ('short'),
            }
            const createdAt = change.after.data().createdAt.toDate().toLocaleDateString('pt-br', options);
            const solvedIn = change.after.data().solvedIn.toDate().toLocaleDateString('pt-br', options);

            mailRef.add({
                'to': change.after.data().emailProvider,
                'message': {
                    'subject': 'Magnum Gold - Requisição Aprovada',
                    'html': "<table><tbody><tr><td><img src='' style='height: 50px' /></td><td style='font-weight: bold'>REQUISIÇÃO MAGNUM GOLD</td></tr><tr><td colspan='2'><hr /></td></tr><tr><td style='font-weight: bold'>N° Requisição</td><td>" + change.after.data().number + "</td></tr><tr><td style='font-weight: bold'>Data da Solicitação:</td><td>" + createdAt + "</td></tr><tr><td style='font-weight: bold'>Data da Aprovação:</td><td>" + solvedIn + "</td></tr><tr><td style='font-weight: bold'>Solicitante:</td><td>" + change.after.data().nameUserRequested + "</td></tr><tr><td style='font-weight: bold'>Aprovada por:</td><td>" + change.after.data().solvedByName + "</td></tr><tr><td style='font-weight: bold'>Fornecedor:</td><td>" + change.after.data().nameProvider + "</td></tr><tr><td style='font-weight: bold'>N° Doc.  Forn.:</td><td>" + change.after.data().docProvider + "</td></tr><tr><td style='font-weight: bold'>Valor:</td><td>R$ " + change.after.data().value + "</td></tr><tr><td style='font-weight: bold'>Descrição:</td><td>" + change.after.data().description + "</td></tr><tr><td colspan='2'><hr /></td></tr></tbody></table>",
                },
            })
        }
        if (change.before.data().status == 'APROVADO' && change.after.data().status == 'NEGADO' && change.after.data().emailProvider != '' && change.after.data().number != null) {

            let options = {
                dateStyle: ('short'),
                timeStyle: ('short'),
            }
            const createdAt = change.after.data().createdAt.toDate().toLocaleDateString('pt-br', options);
            const solvedIn = change.after.data().solvedIn.toDate().toLocaleDateString('pt-br', options);

            mailRef.add({
                'to': change.after.data().emailProvider,
                'message': {
                    'subject': 'Magnum Gold - Requisição Negada',
                    'html': "<table><tbody><tr><td><img src='' style='height: 50px' /></td><td style='font-weight: bold'>REQUISIÇÃO MAGNUM GOLD</td></tr><tr><td colspan='2'><hr /></td></tr><tr><td style='font-weight: bold'>N° Requisição</td><td>" + change.after.data().number + "</td></tr><tr><td style='font-weight: bold'>Data da Solicitação:</td><td>" + createdAt + "</td></tr><tr><td style='font-weight: bold'>Data da Aprovação:</td><td>" + solvedIn + "</td></tr><tr><td style='font-weight: bold'>Solicitante:</td><td>" + change.after.data().nameUserRequested + "</td></tr><tr><td style='font-weight: bold'>Negada por:</td><td>" + change.after.data().solvedByName + "</td></tr><tr><td style='font-weight: bold'>Fornecedor:</td><td>" + change.after.data().nameProvider + "</td></tr><tr><td style='font-weight: bold'>N° Doc.  Forn.:</td><td>" + change.after.data().docProvider + "</td></tr><tr><td style='font-weight: bold'>Valor:</td><td>R$ " + change.after.data().value + "</td></tr><tr><td style='font-weight: bold'>Descrição:</td><td>" + change.after.data().description + "</td></tr><tr><td colspan='2'><hr /></td></tr></tbody></table>",
                },
            })
        }
        return;
    })

// Users
exports.createUser = functions.firestore
    .document('users/{userId}')
    .onCreate((snap, context) => {
        admin.messaging().sendToTopic('user_create', {
            notification: {
                title: 'Usuário ' + snap.data().name + ' cadastrado',
                body: 'Ative o novo usuário e associe-o com algum departamento...',
                clickAction: 'FLUTTER_NOTIFICATION_CLICK',
            }
        })
        return;
    })