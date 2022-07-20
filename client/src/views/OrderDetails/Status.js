import React, { forwardRef, useEffect, useState } from 'react';

// material-ui
import { useTheme } from '@mui/material/styles';
import {
    Box,
    Button,
    Dialog,
    DialogActions,
    DialogContent,
    Divider,
    Grid,
    List,
    ListItem,
    ListItemText,
    Slide,
    Stack,
    TextField,
    Typography
} from '@mui/material';
import {
    Timeline,
    TimelineDot,
    TimelineItem,
    TimelineConnector,
    TimelineContent,
    TimelineOppositeContent,
    TimelineSeparator
} from '@mui/lab';

// project imports
import AnimateButton from 'ui-component/extended/AnimateButton';
import SubCard from 'ui-component/cards/SubCard';
import { gridSpacing } from 'store/constant';

// assets
import FiberManualRecordIcon from '@mui/icons-material/FiberManualRecord';
import { useLocation } from 'react-router-dom';
import Chip from 'ui-component/extended/Chip';
import { useFormik } from 'formik';
import { dispatch } from 'store';

const listBoxSX = {
    bgcolor: (theme) => theme.palette.background.default,
    py: 0
};

const dotSX = {
    p: 0,
    '& > svg': {
        width: 14,
        height: 14
    },
    display: { xs: 'none', md: 'flex' }
};

// tab animation
const Transition = forwardRef((props, ref) => <Slide direction="left" ref={ref} {...props} />);

const Status = () => {
    const theme = useTheme();
    const [delivery, setDelivery] = useState(0);
    const [status, setStatus] = useState(0);
    const location = useLocation();
    const data = location.state;

    // toggle write a review dialog
    const [open, setOpen] = useState(false);
    const handleClickOpenDialog = () => {
        setOpen(true);
    };

    const handleCloseDialog = () => {
        setOpen(false);
    };

    React.useEffect(() => {
        setDelivery(data.livraison);
    });
    React.useEffect(() => {
        setStatus(data.statut);
    });

    const formik = useFormik({
        initialValues: {
            status: '',
            delivery: ''
        },
        onSubmit: () => {
            console.log(status);
            console.log(delivery);
            // dispatch(editEnterpriseInfo(user.id, formik.values, formData));
            // dispatch(
            //     openSnackbar({
            //         open: true,
            //         message: 'Vos modifications ont été enregistrées avec succès',
            //         variant: 'alert',
            //         alert: {
            //             color: 'success'
            //         },
            //         close: false
            //     })
            // );
        }
    });

    return (
        <SubCard title="STATUT DE LA COMMANDE">
            <form onSubmit={formik.handleSubmit}>
                <Grid container spacing={gridSpacing}>
                    <Grid item xs={12} md={12} lg={12}>
                        <Grid container spacing={0}>
                            <Grid item xs={12} sm={12} md={6} lg={3}>
                                <Grid container spacing={1}>
                                    <Grid item xs={12}>
                                        <Typography variant="h5">Date de la commande</Typography>
                                    </Grid>
                                    <Grid item xs={12}>
                                        <Typography variant="body2">
                                            {
                                                // eslint-disable-next-line no-underscore-dangle
                                                new Date(data.horodatage._seconds * 1000).toLocaleTimeString(navigator.language, {
                                                    hour: '2-digit',
                                                    minute: '2-digit',
                                                    day: '2-digit',
                                                    month: '2-digit'
                                                })
                                            }
                                        </Typography>
                                    </Grid>
                                </Grid>
                            </Grid>
                            <Grid item xs={12} sm={6} md={6} lg={2}>
                                <Grid container spacing={1}>
                                    <Grid item xs={12}>
                                        <Typography variant="h5">Statut</Typography>
                                    </Grid>
                                    <Grid item xs={12}>
                                        <Typography variant="body2">
                                            {status === 2 && <Chip label="Terminé" size="small" chipcolor="success" />}
                                            {status === 0 && <Chip label="En Attente" size="small" chipcolor="orange" />}
                                            {status === 1 && <Chip label="En cours" size="small" chipcolor="primary" />}
                                        </Typography>
                                    </Grid>
                                </Grid>
                            </Grid>
                            <Grid item xs={12} sm={6} md={4} lg={3}>
                                <Grid container spacing={1}>
                                    <Grid item xs={12}>
                                        <Typography variant="h5">Mode de livraison</Typography>
                                    </Grid>
                                    <Grid item xs={12}>
                                        <Typography variant="body2">
                                            {delivery === 0 && 'Click & Collect'}
                                            {delivery === 1 && 'Disponible en magasin'}
                                            {delivery === 2 && 'Livraison à domicile'}
                                        </Typography>
                                    </Grid>
                                </Grid>
                            </Grid>
                            <Grid item xs={12} sm={6} md={4} lg={2}>
                                <Grid container spacing={1}>
                                    <Grid item xs={12}>
                                        <Typography variant="h5">Paiement</Typography>
                                    </Grid>
                                    <Grid item xs={12}>
                                        <Typography variant="body2">Carte de Crédit</Typography>
                                    </Grid>
                                </Grid>
                            </Grid>
                            <Grid item xs={12} sm={6} md={4} lg={2}>
                                <Grid container spacing={1}>
                                    <Grid item xs={12}>
                                        <Typography variant="h5">Montant Total</Typography>
                                    </Grid>
                                    <Grid item xs={12}>
                                        <Typography variant="body2">{data.prix} €</Typography>
                                    </Grid>
                                </Grid>
                            </Grid>
                        </Grid>
                    </Grid>
                    <Grid item md={8} lg={9}>
                        <Timeline
                            sx={{
                                '& > li': {
                                    mb: 2.75,
                                    [theme.breakpoints.down('md')]: {
                                        flexDirection: 'column',
                                        '& > div': {
                                            px: 0
                                        },
                                        '& > div:first-of-type': {
                                            textAlign: 'left'
                                        }
                                    }
                                },
                                [theme.breakpoints.down('md')]: {
                                    p: 0
                                }
                            }}
                        >
                            <TimelineItem>
                                <TimelineOppositeContent>
                                    <Typography variant="h6">Commande Payée</Typography>
                                    <Typography variant="body2">14 jun</Typography>
                                </TimelineOppositeContent>
                                <TimelineSeparator>
                                    <TimelineDot color="primary" sx={dotSX}>
                                        <FiberManualRecordIcon />
                                    </TimelineDot>
                                    <TimelineConnector sx={{ bgcolor: 'primary.main' }} />
                                </TimelineSeparator>
                                <TimelineContent sx={{ flex: 3 }}>
                                    <List sx={listBoxSX}>
                                        <ListItem>
                                            <ListItemText primary="Le Paiement a été effectué par Carte Bancaire" />
                                        </ListItem>
                                    </List>
                                </TimelineContent>
                            </TimelineItem>
                            <TimelineItem>
                                <TimelineOppositeContent>
                                    <Typography variant="h6">Commande Validée</Typography>
                                    <Typography variant="body2">12 jun</Typography>
                                </TimelineOppositeContent>
                                <TimelineSeparator>
                                    {(status === 1 && delivery === 1) || status === 2 ? (
                                        <TimelineDot color="primary" sx={dotSX}>
                                            <FiberManualRecordIcon />
                                        </TimelineDot>
                                    ) : (
                                        <TimelineDot sx={dotSX}>
                                            <FiberManualRecordIcon />
                                        </TimelineDot>
                                    )}
                                    {(status === 1 && delivery === 1) || status === 2 ? (
                                        <TimelineConnector sx={{ bgcolor: 'primary.main' }} />
                                    ) : (
                                        <TimelineConnector sx={{ bgcolor: 'grey.400' }} />
                                    )}
                                </TimelineSeparator>
                                <TimelineContent sx={{ flex: 3 }}>
                                    <List sx={listBoxSX}>
                                        <ListItem>
                                            <ListItemText primary="La commande a été validée par l'entreprise" />
                                        </ListItem>
                                    </List>
                                </TimelineContent>
                            </TimelineItem>
                            <TimelineItem>
                                <TimelineOppositeContent>
                                    <Typography variant="h6">Commande Disponible</Typography>
                                    <Typography variant="body2">16 Jun</Typography>
                                </TimelineOppositeContent>
                                <TimelineSeparator>
                                    {(status === 1 && delivery === 1) || status === 2 ? (
                                        <TimelineDot color="primary" sx={dotSX}>
                                            <FiberManualRecordIcon />
                                        </TimelineDot>
                                    ) : (
                                        <TimelineDot sx={dotSX}>
                                            <FiberManualRecordIcon />
                                        </TimelineDot>
                                    )}
                                    {(status === 1 && delivery === 1) || status === 2 ? (
                                        <TimelineConnector sx={{ bgcolor: 'primary.main' }} />
                                    ) : (
                                        <TimelineConnector sx={{ bgcolor: 'grey.400' }} />
                                    )}
                                </TimelineSeparator>
                                <TimelineContent sx={{ flex: 3 }}>
                                    <List sx={listBoxSX}>
                                        <ListItem>
                                            <ListItemText primary="Envoi d'une notification au client" />
                                        </ListItem>
                                    </List>
                                </TimelineContent>
                            </TimelineItem>
                            {delivery === 3 && (
                                <TimelineItem>
                                    <TimelineOppositeContent>
                                        <Typography variant="h6">Commande Expédiée</Typography>
                                        <Typography variant="body2">17 Jun</Typography>
                                    </TimelineOppositeContent>
                                    <TimelineSeparator>
                                        {(status === 1 && delivery === 3) || status === 2 ? (
                                            <TimelineDot color="secondary.main" sx={dotSX}>
                                                <FiberManualRecordIcon />
                                            </TimelineDot>
                                        ) : (
                                            <TimelineDot sx={dotSX}>
                                                <FiberManualRecordIcon />
                                            </TimelineDot>
                                        )}
                                        {(status === 1 && delivery === 3) || status === 2 ? (
                                            <TimelineConnector sx={{ bgcolor: 'primary.main' }} />
                                        ) : (
                                            <TimelineConnector sx={{ bgcolor: 'grey.400' }} />
                                        )}
                                    </TimelineSeparator>
                                    <TimelineContent sx={{ flex: 3 }}>
                                        <List sx={listBoxSX}>
                                            <ListItem>
                                                <ListItemText primary="La commande a été expédiée" />
                                            </ListItem>
                                        </List>
                                    </TimelineContent>
                                </TimelineItem>
                            )}
                            <TimelineItem>
                                <TimelineOppositeContent>
                                    <Typography variant="h6">Commande Livrée</Typography>
                                    <Typography variant="body2">17 Jun</Typography>
                                </TimelineOppositeContent>
                                <TimelineSeparator>
                                    {(status === 1 && delivery === 3) || (status === 2 && delivery === 3) ? (
                                        <TimelineDot color="primary" sx={dotSX}>
                                            <FiberManualRecordIcon />
                                        </TimelineDot>
                                    ) : (
                                        <TimelineDot sx={dotSX}>
                                            <FiberManualRecordIcon />
                                        </TimelineDot>
                                    )}
                                </TimelineSeparator>
                                <TimelineContent sx={{ flex: 3 }}>
                                    <List sx={listBoxSX}>
                                        <ListItem>
                                            <ListItemText primary="La commande a été livrée" />
                                        </ListItem>
                                    </List>
                                </TimelineContent>
                            </TimelineItem>
                        </Timeline>
                        <Grid container spacing={1} justifyContent="center">
                            <Grid item>
                                <Box sx={{ display: { xs: 'block', md: 'none' } }}>
                                    <Button variant="contained" onClick={handleClickOpenDialog}>
                                        Envoyer un message
                                    </Button>
                                    <Dialog
                                        open={open}
                                        TransitionComponent={Transition}
                                        keepMounted
                                        onClose={handleCloseDialog}
                                        sx={{
                                            '&>div:nth-of-type(3)': {
                                                justifyContent: 'flex-end',
                                                '&>div': {
                                                    m: 0,
                                                    borderRadius: '0px',
                                                    maxWidth: 450,
                                                    maxHeight: '100%',
                                                    height: '100vh'
                                                }
                                            }
                                        }}
                                    >
                                        {open && (
                                            <>
                                                <DialogContent>
                                                    <Grid container spacing={1}>
                                                        <Grid item xs={12}>
                                                            <TextField
                                                                id="outlined-basic1"
                                                                fullWidth
                                                                multiline
                                                                rows={10}
                                                                label="Envoyer un message"
                                                            />
                                                        </Grid>
                                                        <Grid item xs={12} />
                                                    </Grid>
                                                </DialogContent>
                                                <DialogActions>
                                                    <AnimateButton>
                                                        <Button variant="contained" color="white">
                                                            Envoyer un message à l&apos;acheteur
                                                        </Button>
                                                    </AnimateButton>
                                                    <Button variant="text" onClick={handleCloseDialog} color="primary">
                                                        Fermer
                                                    </Button>
                                                </DialogActions>
                                            </>
                                        )}
                                    </Dialog>
                                </Box>
                            </Grid>
                        </Grid>
                    </Grid>
                    <Grid item md={4} lg={3}>
                        <Box sx={{ display: { xs: 'none', md: 'block' } }}>
                            <Grid container spacing={1}>
                                <Grid item xs={12}>
                                    <TextField id="outlined-basic2" fullWidth multiline rows={10} label="Envoyer un message" />
                                </Grid>
                                <Grid item xs={12}>
                                    <Stack direction="row">
                                        <AnimateButton>
                                            <Button
                                                variant="contained"
                                                style={{
                                                    color: 'white'
                                                }}
                                            >
                                                Envoyer un message
                                            </Button>
                                        </AnimateButton>
                                    </Stack>
                                </Grid>
                            </Grid>
                        </Box>
                    </Grid>
                    <Grid item xs={12}>
                        <Grid container spacing={1}>
                            <Grid item>
                                <AnimateButton>
                                    <Button
                                        variant="contained"
                                        sx={{ background: theme.palette.error.main, '&:hover': { background: theme.palette.error.dark } }}
                                        style={{
                                            color: 'white'
                                        }}
                                    >
                                        Annuler la commande
                                    </Button>
                                </AnimateButton>
                            </Grid>
                            <Grid item>
                                <AnimateButton>
                                    <Button
                                        type="submit"
                                        variant="contained"
                                        style={{
                                            color: 'white'
                                        }}
                                    >
                                        Changer le statut
                                    </Button>
                                </AnimateButton>
                            </Grid>
                        </Grid>
                    </Grid>
                </Grid>
            </form>
        </SubCard>
    );
};

export default Status;
