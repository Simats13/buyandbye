import React from 'react';

// material-ui
import { useTheme } from '@mui/material/styles';
import { Button, Dialog, DialogActions, DialogContent, DialogContentText, DialogTitle, IconButton, Typography } from '@mui/material';
import DeleteIcon from '@mui/icons-material/Delete';
import { dispatch } from 'store';
import { deleteProducts } from 'store/slices/product';
import { getProducts } from 'store/slices/customer';
import { openSnackbar } from 'store/slices/snackbar';

// ===============================|| UI DIALOG - SWEET ALERT ||=============================== //

export default function DeleteDialog({ idProduct, idSeller, setRows, products, indexProducts, handleCloseDialog }) {
    const theme = useTheme();
    const [open, setOpen] = React.useState(false);
    const handleClickOpen = () => {
        setOpen(true);
    };

    const handleClose = () => {
        setOpen(false);
    };

    const handleDelete = () => {
        dispatch(deleteProducts(idSeller, idProduct));
        setOpen(false);
    };

    return (
        <>
            <IconButton onClick={handleClickOpen} style={{ color: 'red' }} size="large">
                <DeleteIcon />
            </IconButton>
            <Dialog
                open={open}
                onClose={handleClose}
                aria-labelledby="alert-dialog-title"
                aria-describedby="alert-dialog-description"
                sx={{ p: 3 }}
            >
                {open && (
                    <>
                        <DialogTitle id="alert-dialog-title">Supprimer le produit ?</DialogTitle>
                        <DialogContent>
                            <DialogContentText id="alert-dialog-description">
                                <Typography variant="body2" component="span">
                                    Souhaitez-vous supprimer ce produit ?
                                </Typography>
                            </DialogContentText>
                        </DialogContent>
                        <DialogActions sx={{ pr: 2.5 }}>
                            <Button
                                sx={{ color: theme.palette.error.dark, borderColor: theme.palette.error.dark }}
                                onClick={handleClose}
                                color="secondary"
                            >
                                Annuler
                            </Button>
                            <Button variant="contained" size="small" onClick={handleDelete} style={{ color: 'white' }} autoFocus>
                                Supprimer
                            </Button>
                        </DialogActions>
                    </>
                )}
            </Dialog>
        </>
    );
}
