import consumer from "./consumer"

document.addEventListener("DOMContentLoaded", () => {
    const userId = document.querySelector('meta[name="current-user-id"]').getAttribute('content');

    consumer.subscriptions.create(
        {channel: "NotificationChannel", user_id: userId},
        {
            connected() {
                // Called when the subscription is ready for use on the server
                console.log('Connected to NotificationChannel')
            },

            disconnected() {
                // Called when the subscription has been terminated by the server
            },

            received(data) {
                // Handle the received notification data
                const message = data.message;
                const agreementId = data.agreement_id;
                const propertyId = data.property_id;

                // Display the notification (for example, in a notification area)
                const notificationArea = document.getElementById('notification-area');
                if (notificationArea) {
                    notificationArea.innerHTML += `
                    <div class="notification">
                      <p>${message}</p>
                      <a href="/properties/${propertyId}/agreements/${agreementId}">View Agreement</a>
                    </div>
                  `;
                }

                // You can also add more UI behavior here, like showing a pop-up, etc.
                // Display the received message in the modal
                //     document.getElementById('notification-modal-body').innerText = data.message;
                //     // Show the Bootstrap modal
                //     const notificationModal = new bootstrap.Modal(document.getElementById('notificationModal'));
                //     notificationModal.show();
            }
        }
    );
});